SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('dbo.room', 'image_paths') IS NOT NULL
BEGIN
    ALTER TABLE dbo.room ALTER COLUMN image_paths NVARCHAR(MAX) NULL;
END
GO

UPDATE dbo.room
SET available_slots = CASE
    WHEN occupied <= capacity THEN capacity - occupied
    ELSE 0
END
WHERE available_slots IS NULL;
GO

CREATE OR ALTER PROCEDURE dbo.sp_update_room_status
    @room_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @capacity INT, @occupied INT;

    SELECT @capacity = capacity, @occupied = occupied
    FROM dbo.room
    WHERE id = @room_id;

    IF @occupied = 0
        UPDATE dbo.room SET status = 'Available', available_slots = @capacity WHERE id = @room_id;
    ELSE IF @occupied < @capacity
        UPDATE dbo.room SET status = 'Partially Occupied', available_slots = @capacity - @occupied WHERE id = @room_id;
    ELSE IF @occupied >= @capacity
        UPDATE dbo.room SET status = 'Full', available_slots = 0 WHERE id = @room_id;
END
GO

CREATE OR ALTER TRIGGER dbo.tr_update_available_slots
ON dbo.room
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.room
    SET available_slots = capacity - occupied,
        updated_at = GETDATE()
    WHERE id IN (SELECT id FROM inserted);

    DECLARE @room_id INT;
    DECLARE room_cursor CURSOR LOCAL FAST_FORWARD FOR SELECT id FROM inserted;

    OPEN room_cursor;
    FETCH NEXT FROM room_cursor INTO @room_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.sp_update_room_status @room_id;
        FETCH NEXT FROM room_cursor INTO @room_id;
    END

    CLOSE room_cursor;
    DEALLOCATE room_cursor;
END
GO

CREATE OR ALTER VIEW dbo.v_available_rooms AS
SELECT
    r.*,
    h.hostel_name,
    h.address AS hostel_address,
    h.city,
    (r.capacity - r.occupied) AS slots_available
FROM dbo.room r
JOIN dbo.hostel h ON r.hostel_id = h.id
WHERE r.status IN ('Available', 'Partially Occupied')
  AND r.occupied < r.capacity;
GO
