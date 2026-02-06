class HomeController < ApplicationController
  def index
    # La home page se muestra para todos los usuarios (autenticados y anónimos)
    # con contenido condicional según el estado de autenticación
  end
end
