namespace :jscss do
	desc "Clean JS and CSS caches"
	task(:clear) do
		FileUtils.rm(Dir['public/javascripts/cache_*.js'])
		FileUtils.rm(Dir['public/stylesheets/cache_*.js'])
	end
end
