package com.unispace.model;

public class Instructor {
    private String id;
    private String name;
    private String deptName;

    // --- Getters ---
    public String getId()       { return id; }
    public String getName()     { return name; }
    public String getDeptName() { return deptName; }

    // --- Setters ---
    public void setId(String id)           { this.id = id; }
    public void setName(String name)       { this.name = name; }
    public void setDeptName(String dept)   { this.deptName = dept; }
}