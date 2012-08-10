

RACC = racc
RACC_OPTIONS =
RACC_SOURCE = parser.y
RACC_TARGET = parser.tab.rb


$(RACC_TARGET): $(RACC_SOURCE)
	$(RACC) $< -v -o $@


.PHONY : clean
clean:
	rm -f $(RACC_TARGET) *.output
