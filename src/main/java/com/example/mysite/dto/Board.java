package com.example.mysite.dto;

import java.time.LocalDateTime;
import java.util.List;

public class Board {
	private int id;
	private String title;
	private String content;
	private String writer;
	private LocalDateTime createdAt;
	List<UploadFile> files;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getContent() {
		return content;
	}
	public void setContent(String content) {
		this.content = content;
	}
	public String getWriter() {
		return writer;
	}
	public void setWriter(String writer) {
		this.writer = writer;
	}
	public LocalDateTime getCreatedAt() {
		return createdAt;
	}
	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}
	public List<UploadFile> getFiles() {
		return files;
	}
	public void setFiles(List<UploadFile> files) {
		this.files = files;
	}
}
