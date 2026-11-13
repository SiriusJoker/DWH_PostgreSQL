-- This scriipt creates logging table:
CREATE TABLE IF NOT EXISTS bl_cl.load_log(
	log_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	record_log_time timestamptz,	-- time when log record was created
	procedure_name varchar(1000),	-- name of executed procedure/function
	sum_row_num bigint,				-- number of rows affected,
	upd_row_num bigint,				-- number of rows updated,
	ins_row_num bigint,				-- number of rows inserted,
	proc_status varchar(20),		-- SUCCESS / FAILED
	error_message text,				-- NULL if successful
	runtime_start_dt timestamptz,	-- time when procedure/function started
	runtime_end_dt timestamptz		-- time when procedure/function ended
);