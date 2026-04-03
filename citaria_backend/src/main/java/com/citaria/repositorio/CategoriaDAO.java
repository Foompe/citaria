package com.citaria.repositorio;

import com.citaria.modelo.Categoria;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * Repositorio para la entidad Categoria.
 */
@Repository
public interface CategoriaDAO extends JpaRepository<Categoria, Integer> {
}