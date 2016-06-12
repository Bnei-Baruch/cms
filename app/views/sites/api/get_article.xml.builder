xml.instruct!
xml.article {
  xml.category_id(@article[:category_id])
  xml.article_id(@article[:article_id])
  xml.slug(@article[:slug])
  xml.updated_at(@article[:updated_at])
  xml.author(@article[:author])
  xml.title(@article[:title])
  xml.description(@article[:description])
  xml.body(@article[:body])
  xml.num_of_comments(@article[:num_of_comments])
  xml.image(@article[:image])
}
