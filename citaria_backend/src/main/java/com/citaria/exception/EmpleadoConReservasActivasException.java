package com.citaria.exception;

/**
 * Excepción lanzada al intentar dar de baja a un empleado que tiene reservas pendientes.
 */
public class EmpleadoConReservasActivasException extends RuntimeException {

    public EmpleadoConReservasActivasException() {
        super("El empleado tiene reservas activas pendientes de reasignación o cancelación");
    }
}