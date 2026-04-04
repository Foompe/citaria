package com.citaria.controller;

import com.citaria.dto.CategoriaDTO;
import com.citaria.dto.ServicioDTO;
import com.citaria.dto.ServicioSkillDTO;
import com.citaria.dto.SkillDTO;
import com.citaria.service.CatalogoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controlador REST para la gestión del catálogo.
 * Incluye endpoints de servicios, categorías y skills.
 */
@Tag(name = "Catálogo", description = "Gestión de servicios, categorías y skills")
@RestController
@RequestMapping("/api/catalogo")
public class CatalogoController {

    private CatalogoService cataloService;

    @Autowired
    public CatalogoController(CatalogoService cataloService) {
        this.cataloService = cataloService;
    }

    // ===== CATEGORÍAS =====

    @Operation(summary = "Obtener categorías de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/categorias/organizacion/{organizacionId}")
    public ResponseEntity<List<CategoriaDTO>> obtenerCategorias(@PathVariable Integer organizacionId) {
        return ResponseEntity.ok(cataloService.obtenerCategoriasPorOrganizacion(organizacionId));
    }

    @Operation(summary = "Obtener categoría por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Categoría encontrada"),
            @ApiResponse(responseCode = "404", description = "Categoría no encontrada")
    })
    @GetMapping("/categorias/{id}")
    public ResponseEntity<CategoriaDTO> obtenerCategoriaPorId(@PathVariable Integer id) {
        Optional<CategoriaDTO> resultado = cataloService.obtenerCategoriaPorId(id);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Crear categoría en una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Categoría creada correctamente")
    })
    @PostMapping("/categorias/organizacion/{organizacionId}")
    public ResponseEntity<CategoriaDTO> crearCategoria(@PathVariable Integer organizacionId,
                                                       @RequestBody CategoriaDTO dto) {
        return ResponseEntity.status(201).body(cataloService.crearCategoria(organizacionId, dto));
    }

    @Operation(summary = "Actualizar una categoría existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Categoría actualizada correctamente"),
            @ApiResponse(responseCode = "404", description = "Categoría no encontrada")
    })
    @PutMapping("/categorias/{id}")
    public ResponseEntity<CategoriaDTO> actualizarCategoria(@PathVariable Integer id,
                                                            @RequestBody CategoriaDTO dto) {
        Optional<CategoriaDTO> resultado = cataloService.actualizarCategoria(id, dto);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Eliminar una categoría")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Categoría eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Categoría no encontrada")
    })
    @DeleteMapping("/categorias/{id}")
    public ResponseEntity<Void> eliminarCategoria(@PathVariable Integer id) {
        if (cataloService.eliminarCategoria(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // ===== SKILLS =====

    @Operation(summary = "Obtener skills de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/skills/organizacion/{organizacionId}")
    public ResponseEntity<List<SkillDTO>> obtenerSkills(@PathVariable Integer organizacionId) {
        return ResponseEntity.ok(cataloService.obtenerSkillsPorOrganizacion(organizacionId));
    }

    @Operation(summary = "Obtener skill por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Skill encontrada"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @GetMapping("/skills/{id}")
    public ResponseEntity<SkillDTO> obtenerSkillPorId(@PathVariable Integer id) {
        Optional<SkillDTO> resultado = cataloService.obtenerSkillPorId(id);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Crear skill en una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Skill creada correctamente")
    })
    @PostMapping("/skills/organizacion/{organizacionId}")
    public ResponseEntity<SkillDTO> crearSkill(@PathVariable Integer organizacionId,
                                               @RequestBody SkillDTO dto) {
        return ResponseEntity.status(201).body(cataloService.crearSkill(organizacionId, dto));
    }

    @Operation(summary = "Actualizar una skill existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Skill actualizada correctamente"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @PutMapping("/skills/{id}")
    public ResponseEntity<SkillDTO> actualizarSkill(@PathVariable Integer id,
                                                    @RequestBody SkillDTO dto) {
        Optional<SkillDTO> resultado = cataloService.actualizarSkill(id, dto);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Eliminar una skill")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Skill eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @DeleteMapping("/skills/{id}")
    public ResponseEntity<Void> eliminarSkill(@PathVariable Integer id) {
        if (cataloService.eliminarSkill(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // ===== SERVICIOS =====

    @Operation(summary = "Obtener servicios de una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/servicios/organizacion/{organizacionId}")
    public ResponseEntity<List<ServicioDTO>> obtenerServicios(@PathVariable Integer organizacionId) {
        return ResponseEntity.ok(cataloService.obtenerServiciosPorOrganizacion(organizacionId));
    }

    @Operation(summary = "Obtener servicios por categoría")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/servicios/categoria/{categoriaId}")
    public ResponseEntity<List<ServicioDTO>> obtenerServiciosPorCategoria(@PathVariable Integer categoriaId) {
        return ResponseEntity.ok(cataloService.obtenerServiciosPorCategoria(categoriaId));
    }

    @Operation(summary = "Obtener servicio por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Servicio encontrado"),
            @ApiResponse(responseCode = "404", description = "Servicio no encontrado")
    })
    @GetMapping("/servicios/{id}")
    public ResponseEntity<ServicioDTO> obtenerServicioPorId(@PathVariable Integer id) {
        Optional<ServicioDTO> resultado = cataloService.obtenerServicioPorId(id);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Crear servicio en una organización")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Servicio creado correctamente")
    })
    @PostMapping("/servicios/organizacion/{organizacionId}")
    public ResponseEntity<ServicioDTO> crearServicio(@PathVariable Integer organizacionId,
                                                     @RequestBody ServicioDTO dto) {
        return ResponseEntity.status(201).body(cataloService.crearServicio(organizacionId, dto));
    }

    @Operation(summary = "Actualizar un servicio existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Servicio actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Servicio no encontrado")
    })
    @PutMapping("/servicios/{id}")
    public ResponseEntity<ServicioDTO> actualizarServicio(@PathVariable Integer id,
                                                          @RequestBody ServicioDTO dto) {
        Optional<ServicioDTO> resultado = cataloService.actualizarServicio(id, dto);
        if (resultado.isPresent()) {
            return ResponseEntity.ok(resultado.get());
        }
        return ResponseEntity.notFound().build();
    }

    @Operation(summary = "Eliminar un servicio")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Servicio eliminado correctamente"),
            @ApiResponse(responseCode = "404", description = "Servicio no encontrado")
    })
    @DeleteMapping("/servicios/{id}")
    public ResponseEntity<Void> eliminarServicio(@PathVariable Integer id) {
        if (cataloService.eliminarServicio(id)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }

    // ===== SKILLS DE SERVICIO =====

    @Operation(summary = "Obtener skills de un servicio")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/servicios/{id}/skills")
    public ResponseEntity<List<ServicioSkillDTO>> obtenerSkillsServicio(@PathVariable Integer id) {
        return ResponseEntity.ok(cataloService.obtenerSkillsPorServicio(id));
    }

    @Operation(summary = "Asignar skill a un servicio")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Skill asignada correctamente")
    })
    @PostMapping("/servicios/{id}/skills/{skillId}")
    public ResponseEntity<ServicioSkillDTO> asignarSkill(@PathVariable Integer id,
                                                         @PathVariable Integer skillId) {
        return ResponseEntity.status(201).body(cataloService.asignarSkillAServicio(id, skillId));
    }

    @Operation(summary = "Eliminar skill de un servicio")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Skill eliminada correctamente"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @DeleteMapping("/servicios/{id}/skills/{skillId}")
    public ResponseEntity<Void> eliminarSkillServicio(@PathVariable Integer id,
                                                      @PathVariable Integer skillId) {
        if (cataloService.eliminarSkillDeServicio(id, skillId)) {
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}