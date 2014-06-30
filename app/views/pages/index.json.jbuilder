json.array!(@pages) do |page|
	json.extract! page, :id, :name
	json.extract!(page, :content) unless page.content.nil?
	json.extract!(page, :sort_index) unless page.sort_index.nil?
	json.extract!(page, :link) unless page.link.nil?
	json.url page_url(page, format: :json)
end
