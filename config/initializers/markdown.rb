module Markdown
	RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, space_after_headers: true, fenced_code_blocks: true, disable_indented_code_blocks: true)
end
