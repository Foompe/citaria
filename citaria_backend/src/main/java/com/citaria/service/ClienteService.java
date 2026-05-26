package com.citaria.service;

import com.citaria.dto.ClienteDTO;
import org.springframework.data.domain.Page;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

/**
 * Servicio de gestión de clientes.
 */
public interface ClienteService {

    Page<ClienteDTO> obtenerPaginado(String busqueda, int pagina, int tamano);
    List<ClienteDTO> buscarClientes(String dni, String email, String telefono);
    ClienteDTO obtenerPorId(Integer id);
    ClienteDTO crear(ClienteDTO dto);
    ClienteDTO actualizar(Integer id, ClienteDTO dto);
    void subirFotoCliente(Integer id, MultipartFile archivo);
    void anonimizarCliente(Integer id);

}
