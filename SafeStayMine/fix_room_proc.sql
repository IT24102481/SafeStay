IF OBJECT_ID('dbo.sp_update_room_status', 'P') IS NULL
    EXEC('CREATE PROCEDURE dbo.sp_update_room_status AS BEGIN SET NOCOUNT ON; END');
GO
ALTER PROCEDURE dbo.sp_update_room_status
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
