<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>   
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.*" %>   
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	

	//upload 폴더 경로를 저장
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + "modifyBoardAcion dir");
	// 파일 용량을 설정
	int max = 10 * 1024 * 1024;	
	// request객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	// null or 파일값
	System.out.println(mRequest.getOriginalFileName("boardFile") + "modifyBoardAcion param boardFile");
	// mRequest.getOriginalFileName("boardFile") 값이 null이면 board테이블에 title만 수정하는 경우
	
	// 1) board_title 수정, 래핑된 값으로 받아야 함
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	String boardTitle = mRequest.getParameter("boardTitle");

	/* 
		UPDATE board SET board_title = ? WHERE board_no = ? 
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload", "root", "java1234");
	String boardSql = "UPDATE board SET board_title = ? WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boardRow = boardStmt.executeUpdate();
	
	// 2) 이전 boardFile 삭제, 새로운 boardFile추가 테이블을 수정
	if(mRequest.getOriginalFileName("boardFile") != null) {
		// 수정할 파일이 있으면
		// pdf 파일 유효성 검사, PDF 파일이 아니면 새로 업로드 한 파일을 삭제
		if(mRequest.getContentType("boardFile").equals("application/pdf") == false) {
			System.out.println("PDF파일이 아닙니다.");
			String saveFilename = mRequest.getFilesystemName("boardFile");
			// \\ -> / 로 대체해도 프로그램상 자동수정됨.
			File f = new File(dir +"\\"+ saveFilename);
			if(f.exists()) {
				f.delete();
				System.out.println(saveFilename+"PDF파일 삭제");
			} 
			response.sendRedirect(request.getContextPath()+"/modifyBoard.jsp");
		} else { 
			// PDF파일이면 
			// 1) 이전 파일(saveFilename) 삭제
			// 2) db수정(update)	
			System.out.println("PDF파일입니다.");
			String type = mRequest.getContentType("boardFile");
			String originFilename = mRequest.getOriginalFileName("boardFile");
			String saveFilename = mRequest.getFilesystemName("boardFile");
			
			System.out.println(type + "modifyBoardAcion type");
			System.out.println(originFilename + "modifyBoardAcion originFilename");
			System.out.println(saveFilename + "modifyBoardAcion saveFilename");
			
			BoardFile boardFile = new BoardFile();
			boardFile.setBoardFileNo(boardFileNo);
			boardFile.setType(type);
			boardFile.setOriginFilename(originFilename);
			boardFile.setSaveFilename(saveFilename);
			
			// 1) 이전파일 삭제
			String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no =?";
			PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
			saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
			ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
			String preSaveFilename = "";
			if(saveFilenameRs.next()) {
				preSaveFilename = saveFilenameRs.getString("save_filename");
			}
			File f = new File(dir+"/"+preSaveFilename);
			if(f.exists()) {
				System.out.println("PDF파일이 입력되어 기존 PDF파일을 삭제합니다.");
				f.delete();
			}
			
			/* 
				UPDATE board_file SET origin_filename=?, save_filename=? WHERE board_file_no=?
			*/
			
			// 2) 수정된 파일의 정보로 db를 수정
			String boardFileSql = "UPDATE board_file SET origin_filename=?, save_filename=? WHERE board_file_no=?";
			PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
			boardFileStmt.setString(1, boardFile.getOriginFilename());
			boardFileStmt.setString(2, boardFile.getSaveFilename());
			boardFileStmt.setInt(3, boardFile.getBoardFileNo());
			int boardFileRow = boardFileStmt.executeUpdate();
			System.out.println(boardFileStmt + "modifyBoardAction param boardFileStmt");
		}
	}
	 
		response.sendRedirect(request.getContextPath()+"/boardList.jsp"); 
%>