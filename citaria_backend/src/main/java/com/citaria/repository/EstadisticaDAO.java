package com.citaria.repository;

import com.citaria.model.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

/**
 * Repositorio dedicado a las queries de estadísticas agregadas.
 * Separado de ReservaDAO para respetar SRP — las queries analíticas
 * tienen una razón de cambio distinta a las queries operacionales.
 * Se usa SQL nativo porque JPQL no soporta aliases en ORDER BY ni
 * CASE WHEN en ORDER BY con Hibernate.
 */
@Repository
public interface EstadisticaDAO extends JpaRepository<Reserva, Integer> {

    /**
     * Clientes nuevos por mes — primera reserva en el período.
     * Un cliente es "nuevo" si su primera reserva está dentro del rango solicitado.
     */
    @Query(value = """
        SELECT DATE_FORMAT(r.fecha, '%Y-%m') AS periodo,
               COUNT(DISTINCT r.cliente_id) AS total
        FROM reserva r
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND r.estado <> 'cancelada'
          AND r.cliente_id IN (
              SELECT r2.cliente_id
              FROM reserva r2
              WHERE r2.organizacion_id = :organizacionId
                AND r2.estado <> 'cancelada'
              GROUP BY r2.cliente_id
              HAVING MIN(r2.fecha) BETWEEN :desde AND :hasta
          )
        GROUP BY DATE_FORMAT(r.fecha, '%Y-%m')
        ORDER BY DATE_FORMAT(r.fecha, '%Y-%m') ASC
        """, nativeQuery = true)
    List<Object[]> contarClientesNuevosPorMes(@Param("organizacionId") Integer organizacionId,
                                              @Param("desde") LocalDate desde,
                                              @Param("hasta") LocalDate hasta);

    /**
     * Clientes recurrentes por mes — han tenido al menos una reserva previa al período.
     */
    @Query(value = """
        SELECT DATE_FORMAT(r.fecha, '%Y-%m') AS periodo,
               COUNT(DISTINCT r.cliente_id) AS total
        FROM reserva r
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND r.estado <> 'cancelada'
          AND r.cliente_id NOT IN (
              SELECT r2.cliente_id
              FROM reserva r2
              WHERE r2.organizacion_id = :organizacionId
                AND r2.estado <> 'cancelada'
              GROUP BY r2.cliente_id
              HAVING MIN(r2.fecha) BETWEEN :desde AND :hasta
          )
        GROUP BY DATE_FORMAT(r.fecha, '%Y-%m')
        ORDER BY DATE_FORMAT(r.fecha, '%Y-%m') ASC
        """, nativeQuery = true)
    List<Object[]> contarClientesRecurrentesPorMes(@Param("organizacionId") Integer organizacionId,
                                                   @Param("desde") LocalDate desde,
                                                   @Param("hasta") LocalDate hasta);

    /**
     * Fidelización — clientes que repiten visita respecto al total del mes.
     * Un cliente "repite" si tiene más de una reserva en el mismo mes.
     */
    @Query(value = """
        SELECT DATE_FORMAT(r.fecha, '%Y-%m') AS periodo,
               COUNT(DISTINCT r.cliente_id) AS totalClientes,
               COUNT(DISTINCT CASE WHEN sub.visitas > 1 THEN r.cliente_id END) AS repiten
        FROM reserva r
        JOIN (
            SELECT cliente_id,
                   DATE_FORMAT(fecha, '%Y-%m') AS mes,
                   COUNT(id) AS visitas
            FROM reserva
            WHERE organizacion_id = :organizacionId
              AND fecha BETWEEN :desde AND :hasta
              AND estado <> 'cancelada'
            GROUP BY cliente_id, DATE_FORMAT(fecha, '%Y-%m')
        ) sub ON r.cliente_id = sub.cliente_id
             AND DATE_FORMAT(r.fecha, '%Y-%m') = sub.mes
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND r.estado <> 'cancelada'
        GROUP BY DATE_FORMAT(r.fecha, '%Y-%m')
        ORDER BY DATE_FORMAT(r.fecha, '%Y-%m') ASC
        """, nativeQuery = true)
    List<Object[]> calcularFidelizacionPorMes(@Param("organizacionId") Integer organizacionId,
                                              @Param("desde") LocalDate desde,
                                              @Param("hasta") LocalDate hasta);

    /**
     * Reservas totales y canceladas por empleado en el período.
     */
    @Query(value = """
        SELECT rs.empleado_id,
               CONCAT(e.nombre, ' ', e.apellidos) AS nombre,
               COUNT(rs.id) AS totalReservas,
               SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) AS canceladas
        FROM reserva_servicio rs
        JOIN empleado e ON e.id = rs.empleado_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
        GROUP BY rs.empleado_id, e.nombre, e.apellidos
        ORDER BY COUNT(rs.id) DESC
        """, nativeQuery = true)
    List<Object[]> reservasPorEmpleado(@Param("organizacionId") Integer organizacionId,
                                       @Param("desde") LocalDate desde,
                                       @Param("hasta") LocalDate hasta);

    /**
     * Importe total generado por empleado en el período.
     * Solo cuenta líneas activas (no canceladas).
     */
    @Query(value = """
        SELECT rs.empleado_id,
               CONCAT(e.nombre, ' ', e.apellidos) AS nombre,
               SUM(rs.precio_unitario * rs.cantidad) AS importeTotal
        FROM reserva_servicio rs
        JOIN empleado e ON e.id = rs.empleado_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND rs.estado = 'activo'
        GROUP BY rs.empleado_id, e.nombre, e.apellidos
        ORDER BY SUM(rs.precio_unitario * rs.cantidad) DESC
        """, nativeQuery = true)
    List<Object[]> importePorEmpleado(@Param("organizacionId") Integer organizacionId,
                                      @Param("desde") LocalDate desde,
                                      @Param("hasta") LocalDate hasta);

    /**
     * Cancelaciones totales y tasa por empleado en el período.
     */
    @Query(value = """
        SELECT rs.empleado_id,
               CONCAT(e.nombre, ' ', e.apellidos) AS nombre,
               COUNT(rs.id) AS totalReservas,
               SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) AS canceladas
        FROM reserva_servicio rs
        JOIN empleado e ON e.id = rs.empleado_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
        GROUP BY rs.empleado_id, e.nombre, e.apellidos
        ORDER BY SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) DESC
        """, nativeQuery = true)
    List<Object[]> cancelacionesPorEmpleado(@Param("organizacionId") Integer organizacionId,
                                            @Param("desde") LocalDate desde,
                                            @Param("hasta") LocalDate hasta);

    /**
     * Servicios más solicitados en el período.
     */
    @Query(value = """
        SELECT rs.servicio_id,
               s.nombre,
               COUNT(rs.id) AS totalReservas
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND rs.estado = 'activo'
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY COUNT(rs.id) DESC
        """, nativeQuery = true)
    List<Object[]> serviciosMasSolicitados(@Param("organizacionId") Integer organizacionId,
                                           @Param("desde") LocalDate desde,
                                           @Param("hasta") LocalDate hasta);

    /**
     * Importe total generado por servicio en el período.
     */
    @Query(value = """
        SELECT rs.servicio_id,
               s.nombre,
               SUM(rs.precio_unitario * rs.cantidad) AS importeTotal
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND rs.estado = 'activo'
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY SUM(rs.precio_unitario * rs.cantidad) DESC
        """, nativeQuery = true)
    List<Object[]> importePorServicio(@Param("organizacionId") Integer organizacionId,
                                      @Param("desde") LocalDate desde,
                                      @Param("hasta") LocalDate hasta);

    /**
     * Cancelaciones totales y tasa por servicio en el período.
     */
    @Query(value = """
        SELECT rs.servicio_id,
               s.nombre,
               COUNT(rs.id) AS totalReservas,
               SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) AS canceladas
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) DESC
        """, nativeQuery = true)
    List<Object[]> cancelacionesPorServicio(@Param("organizacionId") Integer organizacionId,
                                            @Param("desde") LocalDate desde,
                                            @Param("hasta") LocalDate hasta);
}