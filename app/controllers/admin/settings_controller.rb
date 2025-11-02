class Admin::SettingsController < ApplicationController
  before_action :set_setting, only: %i[ show edit update destroy ]

  # GET /admin/settings or /admin/settings.json
  def index
    @settings = Setting.all
  end

  # GET /admin/settings/1 or /admin/settings/1.json
  def show
  end

  # GET /admin/settings/new
  def new
    @setting = Setting.new
  end

  # GET /admin/settings/1/edit
  def edit
  end

  # POST /admin/settings or /admin/settings.json
  def create
    @setting = Setting.new(setting_params)

    respond_to do |format|
      if @setting.save
        format.html { redirect_to admin_settings_path, notice: "Setting was successfully created." }
        format.json { render :show, status: :created, location: @setting }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/settings/1 or /admin/settings/1.json
  def update
    respond_to do |format|
      if @setting.update(setting_params)
        format.html { redirect_to admin_settings_path, notice: "Setting was successfully updated." }
        format.json { render :show, status: :ok, location: @setting }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/settings/1 or /admin/settings/1.json
  def destroy
    @setting.destroy!

    respond_to do |format|
      format.html { redirect_to admin_settings_path, notice: "Setting was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_setting
      @setting = Setting.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def setting_params
      params.require(:setting).permit(:key, :value)
    end
end
