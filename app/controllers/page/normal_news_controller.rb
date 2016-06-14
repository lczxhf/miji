class Page::NormalNewsController < Page::ApplicationController
	def create
		normal_new = NormalNew.new
		if insert_data(normal_new)
			render plain: '{"errCode":1,"errMsg":"添加成功"}'
		else
			render plain: '{"errCOde":0,"errMsg":"添加失败"}'
		end
	end

	def update
		normal_new = NormalNew.find(params[:id])
		if insert_data(normal_new)
			render plain: '{"errCode":1,"errMsg":"修改成功"}'
		else
			render plain: '{"errCOde":0,"errMsg":"修改失败"}'
		end
	end

	private
	
	def insert_data(normal_new)
		normal_new.shopid = params[:shopid]	
		normal_new.sangna_config_id = SangnaConfig.where(shop_id:params[:shopid]).first.id
		normal_new.title= params[:title]
		normal_new.content = params[:content]
		normal_new.img_url = params[:img_url]
		if normal_new.save
			true
		else
			false
		end

	end
end
