package com.citaria.repository;

import com.citaria.model.Categoria;
import com.citaria.model.Organizacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

/**
 * Repositorio para Categoria.
 */
@Repository
public interface CategoriaDAO extends JpaRepository<Categoria, Integer> {

    List<Categoria> findByOrganizacion(Organizacion organizacion);

}