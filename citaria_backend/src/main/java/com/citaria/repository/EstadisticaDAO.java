package com.citaria.repository;

import com.citaria.model.Reserva;
import com.citaria.repository.projection.FilaImporteEstadistica;
import com.citaria.repository.projection.FilaItemEstadistica;
import com.citaria.repository.projection.FilaMesEstadistica;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Repositorio para estadisticas
 */
@org.springframework.stereotype.Repository
public interface EstadisticaDAO extends Repository<Reserva, Integer> {

    /**
     * Clientes nuevos por mes
     */
    @Query(value = """
        SELECT DATE_FORMAT(r.fecha, '%Y-%m') AS periodo,
               COUNT(DISTINCT r.cliente_id) AS valor1,
               0.0 AS valor2
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
    List<FilaMesEstadistica> contarClientesNuevosPorMes(@Param("organizacionId") Integer organizacionId,
                                                        @Param("desde") LocalDate desde,
                                                        @Param("hasta") LocalDate hasta);

    /**
     * Clientes recurrentes por mes
     */
    @Query(value = """
        SELECT DATE_FORMAT(r.fecha, '%Y-%m') AS periodo,
               COUNT(DISTINCT r.cliente_id) AS valor1,
               0.0 AS valor2
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
    List<FilaMesEstadistica> contarClientesRecurrentesPorMes(@Param("organizacionId") Integer organizacionId,
                                                             @Param("desde") LocalDate desde,
                                                             @Param("hasta") LocalDate hasta);

    /**
     * Clientes que repiten visita en un periodo de tiempo
     */
    @Query(value = """
        SELECT DATE_FORMAT(r.fecha, '%Y-%m') AS periodo,
               COUNT(DISTINCT r.cliente_id) AS valor1,
               COUNT(DISTINCT CASE WHEN sub.visitas > 1 THEN r.cliente_id END) AS valor2
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
    List<FilaMesEstadistica> calcularFidelizacionPorMes(@Param("organizacionId") Integer organizacionId,
                                                        @Param("desde") LocalDate desde,
                                                        @Param("hasta") LocalDate hasta);

    /**
     * Reservas totales y canceladas por empleado.
     */
    @Query(value = """
        SELECT rs.empleado_id AS id,
               CONCAT(e.nombre, ' ', e.apellidos) AS nombre,
               COUNT(rs.id) AS total,
               SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) AS canceladas
        FROM reserva_servicio rs
        JOIN empleado e ON e.id = rs.empleado_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
        GROUP BY rs.empleado_id, e.nombre, e.apellidos
        ORDER BY COUNT(rs.id) DESC
        """, nativeQuery = true)
    List<FilaItemEstadistica> reservasPorEmpleado(@Param("organizacionId") Integer organizacionId,
                                                  @Param("desde") LocalDate desde,
                                                  @Param("hasta") LocalDate hasta);

    /**
     * Ventas totales por empleado
     */
    @Query(value = """
        SELECT rs.empleado_id AS id,
               CONCAT(e.nombre, ' ', e.apellidos) AS nombre,
               SUM(rs.precio_unitario * rs.cantidad) AS importe
        FROM reserva_servicio rs
        JOIN empleado e ON e.id = rs.empleado_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND rs.estado = 'activo'
        GROUP BY rs.empleado_id, e.nombre, e.apellidos
        ORDER BY SUM(rs.precio_unitario * rs.cantidad) DESC
        """, nativeQuery = true)
    List<FilaImporteEstadistica> importePorEmpleado(@Param("organizacionId") Integer organizacionId,
                                                    @Param("desde") LocalDate desde,
                                                    @Param("hasta") LocalDate hasta);

    /**
     * Cancelaciones totales y cancelaciones por empleado
     */
    @Query(value = """
        SELECT rs.empleado_id AS id,
               CONCAT(e.nombre, ' ', e.apellidos) AS nombre,
               COUNT(rs.id) AS total,
               SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) AS canceladas
        FROM reserva_servicio rs
        JOIN empleado e ON e.id = rs.empleado_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
        GROUP BY rs.empleado_id, e.nombre, e.apellidos
        ORDER BY SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) DESC
        """, nativeQuery = true)
    List<FilaItemEstadistica> cancelacionesPorEmpleado(@Param("organizacionId") Integer organizacionId,
                                                       @Param("desde") LocalDate desde,
                                                       @Param("hasta") LocalDate hasta);

    /**
     * Servicios más solicitados en un tiempo determinado
     */
    @Query(value = """
        SELECT rs.servicio_id AS id,
               s.nombre AS nombre,
               COUNT(rs.id) AS total,
               0.0 AS canceladas
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND rs.estado = 'activo'
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY COUNT(rs.id) DESC
        """, nativeQuery = true)
    List<FilaItemEstadistica> serviciosMasSolicitados(@Param("organizacionId") Integer organizacionId,
                                                      @Param("desde") LocalDate desde,
                                                      @Param("hasta") LocalDate hasta);

    /**
     * Candidad de dinero generado en un periodo de tiempo
     */
    @Query(value = """
        SELECT rs.servicio_id AS id,
               s.nombre AS nombre,
               SUM(rs.precio_unitario * rs.cantidad) AS importe
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
          AND rs.estado = 'activo'
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY SUM(rs.precio_unitario * rs.cantidad) DESC
        """, nativeQuery = true)
    List<FilaImporteEstadistica> importePorServicio(@Param("organizacionId") Integer organizacionId,
                                                    @Param("desde") LocalDate desde,
                                                    @Param("hasta") LocalDate hasta);

    /**
     * Cancelaciones totales y cancelaciones por servicio
     */
    @Query(value = """
        SELECT rs.servicio_id AS id,
               s.nombre AS nombre,
               COUNT(rs.id) AS total,
               SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) AS canceladas
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha BETWEEN :desde AND :hasta
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY SUM(CASE WHEN rs.estado = 'cancelado' THEN 1 ELSE 0 END) DESC
        """, nativeQuery = true)
    List<FilaItemEstadistica> cancelacionesPorServicio(@Param("organizacionId") Integer organizacionId,
                                                       @Param("desde") LocalDate desde,
                                                       @Param("hasta") LocalDate hasta);

    //  ESTADÍSTICAS RESUMEN

    /** Total de reservas confirmadas por fecha. */
    @Query(value = """
        SELECT COUNT(*) FROM reserva
        WHERE organizacion_id = :organizacionId
          AND fecha = :fecha
          AND estado <> 'cancelada'
        """, nativeQuery = true)
    Long contarReservasPorFecha(@Param("organizacionId") Integer organizacionId,
                                @Param("fecha") LocalDate fecha);

    /** Total de reservas por mes y año. */
    @Query(value = """
        SELECT COUNT(*) FROM reserva
        WHERE organizacion_id = :organizacionId
          AND YEAR(fecha) = :anio
          AND MONTH(fecha) = :mes
          AND estado <> 'cancelada'
        """, nativeQuery = true)
    Long contarReservasPorMes(@Param("organizacionId") Integer organizacionId,
                              @Param("anio") Integer anio,
                              @Param("mes") Integer mes);

    /** Facturación diaria */
    @Query(value = """
        SELECT COALESCE(SUM(rs.precio_unitario * rs.cantidad), 0)
        FROM reserva_servicio rs
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND r.fecha = :fecha
          AND r.estado = 'completada'
          AND rs.estado = 'activo'
        """, nativeQuery = true)
    BigDecimal facturacionPorFecha(@Param("organizacionId") Integer organizacionId,
                                   @Param("fecha") LocalDate fecha);

    /** Facturación del mes. */
    @Query(value = """
        SELECT COALESCE(SUM(rs.precio_unitario * rs.cantidad), 0)
        FROM reserva_servicio rs
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND YEAR(r.fecha) = :anio
          AND MONTH(r.fecha) = :mes
          AND r.estado = 'completada'
          AND rs.estado = 'activo'
        """, nativeQuery = true)
    BigDecimal facturacionPorMes(@Param("organizacionId") Integer organizacionId,
                                 @Param("anio") Integer anio,
                                 @Param("mes") Integer mes);

    /** Clientes nuevos en el mes. */
    @Query(value = """
        SELECT COUNT(DISTINCT cliente_id) FROM reserva
        WHERE organizacion_id = :organizacionId
          AND estado <> 'cancelada'
          AND cliente_id IN (
              SELECT cliente_id FROM reserva
              WHERE organizacion_id = :organizacionId
                AND estado <> 'cancelada'
              GROUP BY cliente_id
              HAVING MIN(fecha) >= :inicioMes AND MIN(fecha) <= :finMes
          )
        """, nativeQuery = true)
    Long contarClientesNuevosMes(@Param("organizacionId") Integer organizacionId,
                                 @Param("inicioMes") LocalDate inicioMes,
                                 @Param("finMes") LocalDate finMes);

    /** Servicio más solicitado del mes. */
    @Query(value = """
        SELECT s.nombre
        FROM reserva_servicio rs
        JOIN servicio s ON s.id = rs.servicio_id
        JOIN reserva r ON r.id = rs.reserva_id
        WHERE r.organizacion_id = :organizacionId
          AND YEAR(r.fecha) = :anio
          AND MONTH(r.fecha) = :mes
          AND rs.estado = 'activo'
        GROUP BY rs.servicio_id, s.nombre
        ORDER BY COUNT(rs.id) DESC
        LIMIT 1
        """, nativeQuery = true)
    String servicioMasSolicitadoMes(@Param("organizacionId") Integer organizacionId,
                                    @Param("anio") Integer anio,
                                    @Param("mes") Integer mes);
}