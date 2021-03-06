include_directories("${PROJECT_SOURCE_DIR}/src/include")

set(extension_name pg_stat_statements)

add_library(${extension_name} ${PLUGIN_TYPE} ${extension_name}.c)
target_link_libraries(${extension_name} ${contrib_libs})
set_target_properties(${extension_name} PROPERTIES PREFIX "")
add_dependencies(${extension_name} postgres)
if(MSVC)
	gen_def(${extension_name})
endif()
if(NOT PGXS)
	CMAKE_SET_TARGET_FOLDER(${extension_name} contrib)
endif()
install(TARGETS ${extension_name}
		RUNTIME DESTINATION ${PGBINDIR}
		LIBRARY DESTINATION ${LIBDIR})
install(FILES
	${extension_name}.control
	${extension_name}--1.4.sql
	${extension_name}--1.4--1.5.sql
	${extension_name}--1.3--1.4.sql
	${extension_name}--1.2--1.3.sql
	${extension_name}--1.1--1.2.sql
	${extension_name}--1.0--1.1.sql
	${extension_name}--unpackaged--1.0.sql
	DESTINATION ${PGSHAREDIR}/extension)

set(regres_files
	${extension_name}
)
set(REGRESS_OPTS
	--temp-config ${PROJECT_SOURCE_DIR}/contrib/pg_stat_statements/pg_stat_statements.conf
)
# Only for make check and not for installcheck
set(contrib_check_targets ${contrib_check_targets} ${extension_name}_installcheck_tmp PARENT_SCOPE)
REGRESS_CHECK("${extension_name}" "${REGRESS_OPTS}" "${regres_files}")
