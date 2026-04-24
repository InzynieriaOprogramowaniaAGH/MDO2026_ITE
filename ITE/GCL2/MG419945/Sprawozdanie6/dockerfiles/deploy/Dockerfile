FROM nvim-build

WORKDIR /code/neovim/

RUN echo '#!/bin/bash\n\
if [ ! -f ./build/bin/nvim ]; then\n\
    exit 1\n\
fi\n\
./build/bin/nvim --version\n\
    ' >> /tmp/test.sh
RUN chmod +x /tmp/test.sh
CMD ["/tmp/test.sh"]
