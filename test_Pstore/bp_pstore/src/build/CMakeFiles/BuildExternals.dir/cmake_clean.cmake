FILE(REMOVE_RECURSE
  "CMakeFiles/BuildExternals"
)

# Per-language clean rules from dependency scanning.
FOREACH(lang)
  INCLUDE(CMakeFiles/BuildExternals.dir/cmake_clean_${lang}.cmake OPTIONAL)
ENDFOREACH(lang)
