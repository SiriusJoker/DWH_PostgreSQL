-- procedure that populates time dimension

CREATE OR REPLACE PROCEDURE bl_cl.load_dim_time_dd()
LANGUAGE plpgsql
AS $$
DECLARE
    log_start_time timestamptz := clock_timestamp();
    log_end_time   timestamptz;

    log_updated bigint := 0;
    log_inserted bigint := 0;
BEGIN

	WITH dates AS (
		SELECT generate_series('2021-01-01'::date,'2026-12-31'::date,'1 day'::INTERVAL)::date AS dd
	), formatted_data AS (
		SELECT to_char(dates.dd, 'YYYYMMDD')::integer AS dates_surr_id,
			dates.dd AS dates_full_date,
			date_part('day',dates.dd ) AS dates_dom,
			date_part('month',dates.dd) AS dates_m_number,
			to_char(dates.dd,'Month') AS dates_m_name,
			date_part('year',dates.dd) AS dates_y,
			date_part('week',dates.dd) AS dates_wnoy,
			date_part('quarter',dates.dd) AS dates_q,
			to_char(dates.dd,'Day') AS dates_dow,
			date_part('year',dates.dd) AS dates_fy,
			date_part('quarter',dates.dd) AS dates_fq,
			date_part('month',dates.dd) AS dates_fm,
			date_part('week',dates.dd) AS dates_fw
		FROM dates
	)
	INSERT INTO bl_dm.dim_time_dd (
		TIME_SURR_ID,
		FULL_DATE,
		DAY_NUMBER_OF_MONTH,
		MONTH_NUMBER,
		MONTH_NAME,
		YEAR,
		WEEK_NUMBER_OF_YEAR,
		QUARTER_NUMBER,
		DAY_OF_WEEK,
		FISCAL_YEAR,
		FISCAL_QUARTER,
		FISCAL_MONTH,
		FISCAL_WEEK)
	SELECT dates_surr_id,
		dates_full_date,
		dates_dom,
		dates_m_number,
		dates_m_name,
		dates_y,
		dates_wnoy,
		dates_q,
		dates_dow,
		dates_fy,
		dates_fq,
		dates_fm,
		dates_fw
	FROM formatted_data
	ON CONFLICT DO NOTHING ;

	GET DIAGNOSTICS log_inserted = ROW_COUNT;

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_time_dd',
		log_updated + log_inserted,
		log_updated,
		log_inserted,
		'SUCCESS',
		NULL,
		log_start_time,
		log_end_time
    );

EXCEPTION
WHEN OTHERS THEN

	log_end_time := clock_timestamp();

	CALL bl_cl.write_log(
		'load_dim_time_dd',
		log_updated + log_inserted,
		log_updated,
		log_inserted,
		'FAILED',
		SQLERRM,
		log_start_time,
		log_end_time
    );

END;
$$;
