-- procedure that will be called inside 'load' procedures to write log
CREATE OR REPLACE PROCEDURE bl_cl.write_log(
	in_procedure_name  varchar(1000),
	in_sum_row_num     bigint,
	in_upd_row_num     bigint,
	in_ins_row_num     bigint,
	in_proc_status     varchar(20),
	in_error_message 	text,	
	in_runtime_start   timestamptz,
	in_runtime_end     timestamptz
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO bl_cl.load_log
    (
        record_log_time,
        procedure_name,
        sum_row_num,
        upd_row_num,
        ins_row_num,
        proc_status,
		error_message,
        runtime_start_dt,
        runtime_end_dt
    )
    VALUES
    (
        CURRENT_TIMESTAMP,
        in_procedure_name,
        in_sum_row_num,
        in_upd_row_num,
        in_ins_row_num,
        in_proc_status,
		in_error_message,
        in_runtime_start,
        in_runtime_end
    );
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION
            'Failed to write log. Error: %',
            SQLERRM;

END;
$$;