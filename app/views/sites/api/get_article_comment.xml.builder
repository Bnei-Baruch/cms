xml.instruct!
xml.comment {
  if @comment
    xml.title(@comment.title)
    xml.author(@comment.name)
    xml.publish_time(@comment.created_at)
    xml.body(@comment.body)
  end
}
