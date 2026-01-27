class WorldsController < ApplicationController
  def index
    target_city = City.global.first
    redirect_to city_path(target_city), status: :found
  end

  def show
    world = World.find_by!(slug: params[:slug])

    target_city = City.find_by(
      target_scope_type: :specific_world,
      target_world_id: world.id
    )

    target_city ||= world.cities.order(:id).first

    if target_city
      redirect_to city_path(target_city), status: :found
    else
      render plain: "表示可能な都市が見つかりません。", status: :not_found
    end
  end
end
