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
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para la gestión del catálogo.
 * Incluye endpoints de servicios, categorías y skills.
 * La organización se resuelve automáticamente desde el token JWT.
 */
@Tag(name = "Catálogo", description = "Gestión de servicios, categorías y skills")
@RestController
@RequestMapping("/api/catalogo")
public class CatalogoController {

    private final CatalogoService cataloService;

    public CatalogoController(CatalogoService cataloService) {
        this.cataloService = cataloService;
    }

    // CATEGORÍAS

    @Operation(summary = "Obtener categorías de la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/categorias")
    public ResponseEntity<List<CategoriaDTO>> obtenerCategorias() {
        return ResponseEntity.ok(cataloService.obtenerCategorias());
    }

    @Operation(summary = "Obtener categoría por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Categoría encontrada"),
            @ApiResponse(responseCode = "404", description = "Categoría no encontrada")
    })
    @GetMapping("/categorias/{id}")
    public ResponseEntity<CategoriaDTO> obtenerCategoriaPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(cataloService.obtenerCategoriaPorId(id));
    }

    @Operation(summary = "Crear categoría en la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Categoría creada correctamente")
    })
    @PostMapping("/categorias")
    public ResponseEntity<CategoriaDTO> crearCategoria(@Valid @RequestBody CategoriaDTO dto) {
        return ResponseEntity.status(201).body(cataloService.crearCategoria(dto));
    }

    @Operation(summary = "Actualizar una categoría existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Categoría actualizada correctamente"),
            @ApiResponse(responseCode = "404", description = "Categoría no encontrada")
    })
    @PutMapping("/categorias/{id}")
    public ResponseEntity<CategoriaDTO> actualizarCategoria(@PathVariable Integer id,
                                                            @Valid @RequestBody CategoriaDTO dto) {
        return ResponseEntity.ok(cataloService.actualizarCategoria(id, dto));
    }

    @Operation(summary = "Desactivar una categoría — borrado lógico irreversible")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Categoría desactivada correctamente"),
            @ApiResponse(responseCode = "404", description = "Categoría no encontrada")
    })
    @DeleteMapping("/categorias/{id}")
    public ResponseEntity<Void> eliminarCategoria(@PathVariable Integer id) {
        cataloService.eliminarCategoria(id);
        return ResponseEntity.noContent().build();
    }

    // SKILLS

    @Operation(summary = "Obtener skills de la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/skills")
    public ResponseEntity<List<SkillDTO>> obtenerSkills() {
        return ResponseEntity.ok(cataloService.obtenerSkills());
    }

    @Operation(summary = "Obtener skill por ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Skill encontrada"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @GetMapping("/skills/{id}")
    public ResponseEntity<SkillDTO> obtenerSkillPorId(@PathVariable Integer id) {
        return ResponseEntity.ok(cataloService.obtenerSkillPorId(id));
    }

    @Operation(summary = "Crear skill en la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Skill creada correctamente")
    })
    @PostMapping("/skills")
    public ResponseEntity<SkillDTO> crearSkill(@Valid @RequestBody SkillDTO dto) {
        return ResponseEntity.status(201).body(cataloService.crearSkill(dto));
    }

    @Operation(summary = "Actualizar una skill existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Skill actualizada correctamente"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @PutMapping("/skills/{id}")
    public ResponseEntity<SkillDTO> actualizarSkill(@PathVariable Integer id,
                                                    @Valid @RequestBody SkillDTO dto) {
        return ResponseEntity.ok(cataloService.actualizarSkill(id, dto));
    }

    @Operation(summary = "Desactivar una skill — borrado lógico irreversible")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Skill desactivada correctamente"),
            @ApiResponse(responseCode = "404", description = "Skill no encontrada")
    })
    @DeleteMapping("/skills/{id}")
    public ResponseEntity<Void> eliminarSkill(@PathVariable Integer id) {
        cataloService.eliminarSkill(id);
        return ResponseEntity.noContent().build();
    }

    // ===== SERVICIOS =====

    @Operation(summary = "Obtener servicios de la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista obtenida correctamente")
    })
    @GetMapping("/servicios")
    public ResponseEntity<List<ServicioDTO>> obtenerServicios() {
        return ResponseEntity.ok(cataloService.obtenerServicios());
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
        return ResponseEntity.ok(cataloService.obtenerServicioPorId(id));
    }

    @Operation(summary = "Crear servicio en la organización autenticada")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Servicio creado correctamente")
    })
    @PostMapping("/servicios")
    public ResponseEntity<ServicioDTO> crearServicio(@Valid @RequestBody ServicioDTO dto) {
        return ResponseEntity.status(201).body(cataloService.crearServicio(dto));
    }

    @Operation(summary = "Actualizar un servicio existente")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Servicio actualizado correctamente"),
            @ApiResponse(responseCode = "404", description = "Servicio no encontrado")
    })
    @PutMapping("/servicios/{id}")
    public ResponseEntity<ServicioDTO> actualizarServicio(@PathVariable Integer id,
                                                          @Valid @RequestBody ServicioDTO dto) {
        return ResponseEntity.ok(cataloService.actualizarServicio(id, dto));
    }

    @Operation(summary = "Desactivar un servicio — borrado lógico irreversible")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Servicio desactivado correctamente"),
            @ApiResponse(responseCode = "404", description = "Servicio no encontrado")
    })
    @DeleteMapping("/servicios/{id}")
    public ResponseEntity<Void> eliminarServicio(@PathVariable Integer id) {
        cataloService.eliminarServicio(id);
        return ResponseEntity.noContent().build();
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