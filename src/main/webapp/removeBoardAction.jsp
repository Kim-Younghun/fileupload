<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>   
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%

	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + "modifyBoardAcion dir");
	int max = 10 * 1024 * 1024;	
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	String saveFilename = mRequest.getParameter("saveFilename");
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	
	System.out.println(saveFilename + "removeBoardAcion saveFilename");
	System.out.println(boardNo + "removeBoardAcion boardNo");
	System.out.println(boardFileNo + "removeBoardAcion boardFileNo");
	
	/* 
		DELETE FROM board WHERE board_no=?
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload", "root", "java1234");
	// FROM board_file시 board_file 테이블의 값만 삭제된다.
	String fileRemoveSql = "DELETE FROM board WHERE board_no=?";
	PreparedStatement fileRemoveStmt = conn.prepareStatement(fileRemoveSql);
	fileRemoveStmt.setInt(1, boardNo);
	System.out.println(fileRemoveStmt + "removeBoardAcion fileRemoveStmt");
	int row = fileRemoveStmt.executeUpdate();
	System.out.println(row + "removeBoardAcion row");
	
	if(row==1) {
		File f = new File(dir +"\\"+ saveFilename);
		System.out.println(f + "removeBoardAcion f");
		if(f.exists()) {
			f.delete();
			System.out.println(saveFilename+"PDF파일 삭제");
		} 
		
		response.sendRedirect(request.getContextPath()+"/boardList.jsp"); 
		
	} else {
		System.out.println("파일 삭제 실패");
		response.sendRedirect(request.getContextPath()+"/removeBoard.jsp");
	}
%>