# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# =============================================================================
# Perfiles predefinidos de Iron Hills
# =============================================================================

[
  {
    name: "Iron hill dwarf",
    warband_class: "Iron hills",
    member_type: "warrior",
    rank: nil,
    movimiento: 5,
    lucha: 4,
    proyectiles: 4,
    fuerza: 4,
    defensa: 6,
    ataques: 1,
    heridas: 1,
    coraje: 4,
    inteligencia: 2,
    might: 0,
    will: 0,
    fate: 0,
    experience: 0,
    ranking: 9
  },
  {
    name: "Iron hill goat rider",
    warband_class: "Iron hills",
    member_type: "warrior",
    rank: nil,
    movimiento: 6,
    lucha: 4,
    proyectiles: 4,
    fuerza: 4,
    defensa: 5,
    ataques: 1,
    heridas: 1,
    coraje: 4,
    inteligencia: 2,
    might: 0,
    will: 0,
    fate: 0,
    experience: 0,
    ranking: 13
  }
].each do |attrs|
  MemberProfile.find_or_create_by!(name: attrs[:name], warband_class: attrs[:warband_class]) do |p|
    p.assign_attributes(attrs)
  end
end
