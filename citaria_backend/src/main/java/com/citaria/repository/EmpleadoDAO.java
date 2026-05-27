package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.Organizacion;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repositorio para Empleado.
 */
@Repository
public interface EmpleadoDAO extends JpaRepository<Empleado, Integer> {

    List<Empleado> findByOrganizacion(Organizacion organizacion);
    List<Empleado> findByOrganizacionAndActivo(Organizacion organizacion, Boolean activo);

    /**
     * Bloquea en exclusiva la fila del empleado para evitar reservas concurrentes.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT e FROM Empleado e WHERE e.id = :id")
    Optional<Empleado> findByIdConLock(@Param("id") Integer id);

}