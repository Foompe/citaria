package com.citaria.repositorio;

import com.citaria.modelo.Empleado;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Empleado.
 */
@Repository
public interface EmpleadoDAO extends JpaRepository<Empleado, Integer> {
}