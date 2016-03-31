set(tmp_check_folder ${CMAKE_BINARY_DIR}/src/test/regress/tmp_install)

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
	set(env_cmd
		${CMAKE_COMMAND} -E env
		"DYLD_LIBRARY_PATH=$ENV{DESTDIR}${LIBDIR}:$DYLD_LIBRARY_PATH"
	)
	set(tmp_env_cmd
		${CMAKE_COMMAND} -E env
		"DYLD_LIBRARY_PATH=${tmp_check_folder}${LIBDIR}:$DYLD_LIBRARY_PATH"
	)
elif(CMAKE_SYSTEM_NAME STREQUAL "AIX")
	set(env_cmd
		${CMAKE_COMMAND} -E env
		"LIBPATH=$ENV{DESTDIR}${LIBDIR}:$LIBPATH"
	)
	set(tmp_env_cmd
		${CMAKE_COMMAND} -E env
		"LIBPATH=${tmp_check_folder}${LIBDIR}:$LIBPATH"
	)
else()
	set(env_cmd
		${CMAKE_COMMAND} -E env
		"LD_LIBRARY_PATH=$ENV{DESTDIR}${LIBDIR}:$LD_LIBRARY_PATH"
	)
	set(tmp_env_cmd
		${CMAKE_COMMAND} -E env
		"LD_LIBRARY_PATH=${tmp_check_folder}${LIBDIR}:$LD_LIBRARY_PATH"
	)
endif()

if(MSVC)
	#Need rewrite
	set(pre_pg_regress_check
		${PGBINDIR}/pg_regress${CMAKE_EXECUTABLE_SUFFIX}
		--inputdir="${CMAKE_SOURCE_DIR}/src/test/regress"
		--temp-instance="tmp_check"
		--encoding=UTF8
		--no-locale
	)
else(MSVC)
	set(pre_pg_regress_check
		${CMAKE_BINARY_DIR}/src/test/regress/${CMAKE_INSTALL_CONFIG_NAME}/pg_regress${CMAKE_EXECUTABLE_SUFFIX}
		--inputdir="${CMAKE_SOURCE_DIR}/src/test/regress"
		--temp-instance="tmp_check"
		--encoding=UTF8
		--no-locale
	)
endif()

set(pg_regress_check
	${env_cmd}
	${pre_pg_regress_check}
	--bindir=$ENV{DESTDIR}${PGBINDIR}
)

set(pg_regress_check_tmp
	${tmp_env_cmd}
	${pre_pg_regress_check}
	--bindir=${tmp_check_folder}${PGBINDIR}
)

if(MAX_CONNECTIONS)
	set(MAXCONNOPT "${MAXCONNOPT} --max-connections=${MAX_CONNECTIONS}")
endif()

if(TEMP_CONFIG)
	set(TEMP_CONF "${TEMP_CONF} --temp-config=${TEMP_CONFIG}")
endif()

macro(REGRESS_CHECK TARGET_NAME REGRESS_OPTS REGRESS_FILES)
	add_custom_target(${TARGET_NAME}_installcheck_tmp
		COMMAND ${pg_regress_check_tmp} ${REGRESS_OPTS} --dlpath=${tmp_check_folder}${LIBDIR} ${MAXCONNOPT} ${TEMP_CONF} ${REGRESS_FILES}
		DEPENDS tablespace-setup
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	)

	add_custom_target(${TARGET_NAME}_check
		COMMAND ${CMAKE_COMMAND} -E remove_directory ${tmp_check_folder}
		COMMAND make install DESTDIR=${tmp_check_folder}
		COMMAND make ${TARGET_NAME}_installcheck_tmp DESTDIR=${tmp_check_folder}
		DEPENDS tablespace-setup
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)
endmacro(REGRESS_CHECK TARGET_NAME REGRESS_OPTS REGRESS_FILES)
