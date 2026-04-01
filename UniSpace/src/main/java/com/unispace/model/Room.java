package com.unispace.model;

import java.io.Serializable;

public class Room implements Serializable {

    private static final long serialVersionUID = 1L;

    private String building;
    private String roomNumber;
    private int capacity;

    // ================= GETTERS =================
    public String getBuilding() { return building; }
    public String getRoomNumber() { return roomNumber; }
    public int getCapacity() { return capacity; }

    // ================= SETTERS =================
    public void setBuilding(String building) {
        this.building = building != null ? building.trim() : null;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber != null ? roomNumber.trim() : null;
    }

    public void setCapacity(int capacity) {
        if (capacity < 0) capacity = 0;
        this.capacity = capacity;
    }

    // ================= HELPER =================
    public String getFullRoom() {
        if (building == null || roomNumber == null) return null;
        return building + "-" + roomNumber;
    }

    // ================= DEBUG =================
    @Override
    public String toString() {
        return "Room{" +
                "building='" + building + '\'' +
                ", roomNumber='" + roomNumber + '\'' +
                ", capacity=" + capacity +
                '}';
    }
}