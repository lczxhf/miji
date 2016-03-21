RailsAdmin.config do |config|
	config.authorize_with do
	      if  params[:olivia] == 'true' 
			cookies["olivia"]=true
	      end
		redirect_to "/404.html" unless params[:olivia] == 'true' || cookies["olivia"] == 'true'
	end

	config.actions do 
		dashboard
		index
		show
		show_in_app
	end
end
