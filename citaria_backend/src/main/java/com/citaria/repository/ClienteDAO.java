package com.citaria.repository;

import com.citaria.model.Cliente;
import com.citaria.model.Organizacion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

/**
 * Repositorio para Cliente.
 */
@Repository
public interface ClienteDAO extends JpaRepository<Cliente, Integer> {

    List<Cliente> findByTelefonoAndOrganizacion(String telefono, Organizacion organizacion);
    Optional<Cliente> findByEmailAndOrganizacion(String email, Organizacion organizacion);
    Optional<Cliente> findByDniAndOrganizacion(String dni, Organizacion organizacion);

    @Query("SELECT c FROM Cliente c WHERE c.organizacion = :org AND c.anonimizadoAt IS NULL " +
            "AND (:busqueda IS NULL " +
            "OR LOWER(c.nombre) LIKE LOWER(CONCAT('%', :busqueda, '%')) " +
            "OR LOWER(c.apellidos) LIKE LOWER(CONCAT('%', :busqueda, '%')) " +
            "OR LOWER(c.email) LIKE LOWER(CONCAT('%', :busqueda, '%')) " +
            "OR LOWER(c.telefono) LIKE LOWER(CONCAT('%', :busqueda, '%')))")
    Page<Cliente> buscarPaginado(@Param("org") Organizacion org,
                                 @Param("busqueda") String busqueda,
                                 Pageable pageable);

}