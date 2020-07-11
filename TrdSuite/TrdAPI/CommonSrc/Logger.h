#ifndef LOGGER_H_
#define LOGGER_H_


class CLogger
	{
public:	
	static TInt iLogIndent;
	
private:
	static bool iFirstTimeLoad;
	FILE*  iFile;
	
public:
	CLogger(const char* aFileName);

	CLogger();
	
	~CLogger();

	bool Open(const char* aFileName);
	void Log(const char* sLine);

	};

#endif
