output "index_id" {
  description = "The ID of the created Vertex AI vector search index (null if not created)"
  value       = try(google_vertex_ai_index.index[0].id, null)
}

output "endpoint_id" {
  description = "The ID of the created Vertex AI index endpoint for serving queries (null if not created)"
  value       = try(google_vertex_ai_index_endpoint.endpoint[0].id, null)
}
