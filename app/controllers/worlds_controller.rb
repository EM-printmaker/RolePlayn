class WorldsController < ApplicationController
  def index
    redirect_to city_path(City.global_node), status: :found
  end

  def show
    world = World.find_by!(slug: params[:slug])
    target_city = world.observation_city

    if target_city
      redirect_to city_path(target_city), status: :found
    else
      render_not_found
    end
  end

  private

    def render_not_found
      render plain: "表示可能な都市が見つかりません。", status: :not_found
    end
end
