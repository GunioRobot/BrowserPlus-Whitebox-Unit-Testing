FILE(REMOVE_RECURSE
  "CMakeFiles/JSONRequest"
  "JSONRequest/json/json/common.rb"
  "JSONRequest/json/json/pure/generator.rb"
  "JSONRequest/json/json/pure/parser.rb"
  "JSONRequest/json/json/pure.rb"
  "JSONRequest/json/json/version.rb"
  "JSONRequest/json/json.rb"
  "JSONRequest/JSONRequest.rb"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/JSONRequest.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
