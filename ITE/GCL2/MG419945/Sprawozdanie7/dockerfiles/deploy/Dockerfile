FROM nvim-build

WORKDIR /code/neovim/

RUN echo '#!/bin/bash\n\
if [ ! -f ./nvim ]; then\n\
    exit 1\n\
fi\n\
./nvim --version\n\
    ' >> /tmp/test.sh
RUN chmod +x /tmp/test.sh
CMD ["/tmp/test.sh"]
