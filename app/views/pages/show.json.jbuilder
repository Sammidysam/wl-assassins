json.extract! @page, :id, :name, :created_at, :updated_at
json.extract!(@page, :content) unless @page.content.nil?
json.extract!(@page, :sort_index) unless @page.sort_index.nil?
json.extract!(@page, :link) unless @page.link.nil?
