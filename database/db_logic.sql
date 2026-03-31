CREATE OR REPLACE FUNCTION fn_check_room_availability(
    p_building VARCHAR,
    p_room VARCHAR,
    p_time_slot VARCHAR,
    p_sem INTEGER,
    p_year INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Booking
        WHERE building = p_building
        AND room_number = p_room
        AND time_slot_id = p_time_slot
        AND semester = p_sem
        AND year = p_year
        AND status = 'ACTIVE'
    ) THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;