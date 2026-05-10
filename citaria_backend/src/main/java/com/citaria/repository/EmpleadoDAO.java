package com.citaria.repository;

import com.citaria.model.Empleado;
import com.citaria.model.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Repositorio para Empleado.
 */
@Repository
public interface EmpleadoDAO extends JpaRepository<Empleado, Integer> {

    List<Empleado> findByOrganizacion(Organizacion organizacion);
    List<Empleado> findByOrganizacionAndActivo(Organizacion organizacion, Boolean activo);

}