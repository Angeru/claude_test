namespace :profiles do
  desc "Elimina todos los MemberProfile existentes e importa las fichas de MESBG desde tmp/mesbg_data/fichas_extraidas.json"
  task import: :environment do
    json_path = Rails.root.join("tmp/mesbg_data/fichas_extraidas.json")
    abort "No se encuentra #{json_path}" unless File.exist?(json_path)

    fichas = JSON.parse(File.read(json_path))

    puts "Eliminando #{MemberProfile.count} perfiles existentes..."
    MemberProfile.delete_all

    errors = []
    created = 0

    fichas.each do |ficha|
      profile = MemberProfile.new(
        name:        ficha["name"],
        member_type: ficha["member_type"],
        movimiento:  ficha["movimiento"],
        lucha:       ficha["lucha"],
        proyectiles: ficha["proyectiles"],
        fuerza:      ficha["fuerza"],
        defensa:     ficha["defensa"],
        ataques:     ficha["ataques"],
        heridas:     ficha["heridas"],
        coraje:      ficha["coraje"],
        inteligencia: ficha["inteligencia"],
        might:       ficha["might"],
        will:        ficha["will"],
        fate:        ficha["fate"]
      )

      if profile.save
        created += 1
      else
        errors << "#{ficha["name"]} (#{ficha["army_list"]}): #{profile.errors.full_messages.join(", ")}"
      end
    end

    puts "Importados: #{created} perfiles"
    if errors.any?
      puts "Errores (#{errors.count}):"
      errors.each { |e| puts "  - #{e}" }
    end
  end
end
