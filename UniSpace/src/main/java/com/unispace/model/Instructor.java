package com.unispace.model;

import java.io.Serializable;

public class Instructor implements Serializable {

    private static final long serialVersionUID = 1L;

    private String id;
    private String name;
    private String deptName;

    // ================= GETTERS =================
    public String getId() { return id; }
    public String getName() { return name; }
    public String getDeptName() { return deptName; }

    // ================= SETTERS =================
    public void setId(String id) {
        this.id = id != null ? id.trim() : null;
    }

    public void setName(String name) {
        this.name = name != null ? name.trim() : null;
    }

    public void setDeptName(String deptName) {
        this.deptName = deptName != null ? deptName.trim() : null;
    }

    // ================= DEBUG =================
    @Override
    public String toString() {
        return "Instructor{" +
                "id='" + id + '\'' +
                ", name='" + name + '\'' +
                ", deptName='" + deptName + '\'' +
                '}';
    }
}