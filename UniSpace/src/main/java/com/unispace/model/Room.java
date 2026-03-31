package com.unispace.model;

public class Room {
    private String building;
    private String roomNumber;
    private int    capacity;

    // --- Getters ---
    public String getBuilding()    { return building; }
    public String getRoomNumber()  { return roomNumber; }
    public int    getCapacity()    { return capacity; }

    // --- Setters ---
    public void setBuilding(String building)     { this.building = building; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }
    public void setCapacity(int capacity)        { this.capacity = capacity; }
}