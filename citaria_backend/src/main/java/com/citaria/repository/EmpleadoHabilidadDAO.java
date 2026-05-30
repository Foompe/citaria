package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.EmpleadoHabilidad;
import com.citaria.model.EmpleadoHabilidadId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para EmpleadoHabilidad.
 */
@Repository
public interface EmpleadoHabilidadDAO extends JpaRepository<EmpleadoHabilidad, EmpleadoHabilidadId> {

    List<EmpleadoHabilidad> findByEmpleado(Empleado empleado);

    /**
     * Compara de una lista las habilidades y devuelve el número de las que coinciden, si es el mismo es que puede
     * dar ese servicio.
     */
    @Query("SELECT COUNT(es) FROM EmpleadoHabilidad es WHERE es.empleado = :empleado AND es.habilidad.id IN :habilidadIds")
    long contarHabilidadesQueCoinciden(@Param("empleado") Empleado empleado, @Param("habilidadIds") List<Integer> habilidadIds);
}