#import "/src/config.typ": default-opts, merge-config
#let cfg = merge-config(default-opts, (:))
#assert("node-renderers" in cfg)
