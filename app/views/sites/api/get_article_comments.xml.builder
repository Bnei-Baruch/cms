xml.instruct!
xml.comments do
  xml.total_items(@comments.size)
  for comment in @comments
    has_content = !(comment.body.empty?) rescue false
    xml.comment do
      xml.comment_id(comment.id)
      xml.title(comment.title)
      xml.has_content(has_content)
      xml.author(comment.name)
      xml.publish_time(comment.created_at)
    end
    
  end
end
