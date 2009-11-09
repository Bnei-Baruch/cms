xml.instruct!
xml.comments do
  for comment in @comments
    xml.comment do
      xml.comment_id(comment.id)
      xml.title(comment.title)
      xml.author(comment.name)
      xml.publish_time(comment.created_at)
    end
  end
end
