<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Redirect to the main chat application
    response.sendRedirect(request.getContextPath() + "/chat");
%>