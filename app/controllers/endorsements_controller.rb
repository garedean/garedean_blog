class EndorsementsController < ApplicationController
  def index
    @endorsements = Endorsement.order("position")
  end

  def create
    @endorsement = Endorsement.new(endorsement_params)
    @endorsement.save
    redirect_to :back
  end

  def destroy
    @endorsement = Endorsement.find(params[:id])
    @endorsement.destroy
    redirect_to :back
  end

  def edit_multiple
    @endorsements = Endorsement.order("position")
    @endorsement = Endorsement.new
  end

  def update_multiple
    Endorsement.update(params[:endorsements].keys, params[:endorsements].values)

    records_destroyed_count = destroy_empties

    # Customize flash message depending on whether empties were destroyed
    if records_destroyed_count > 0
      flash[:notice] = "#{view_context.pluralize( records_destroyed_count, 'record')} destroyed, all others updated!"
    else
      flash[:notice] = "Endorsements updated!"
    end
    redirect_to edit_multiple_endorsements_path
  end

  def sort
    params[:endorsement].each_with_index do |id, index|
      Endorsement.where(id: id).update_all(position: index + 1)
    end
    flash[:notice] = "References reordered!"
    render nothing: true
  end

  private

  def endorsement_params
    params.require(:endorsement).permit(:quote)
  end

  def endorsements_params
    params.require(:endorsements).permit!
  end

  def destroy_empties
    records_destroyed = 0

    endorsements_params.each do |id, endorsement|
      if endorsement[:quote].empty?
        Endorsement.destroy(id.to_i)
        records_destroyed += 1
      end
    end

    records_destroyed
  end
end
