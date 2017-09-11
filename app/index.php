<?php
    require('app.php');
    $test = 1;
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <title>
        Vamplistic: Vagrant-Based LAMP Environment
    </title>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" type="text/css" href="css/boostrap/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="css/boostrap/bootstrap-grid.min.css">
    <link rel="stylesheet" type="text/css" href="css/boostrap/bootstrap-reboot.min.css">
    <link rel="stylesheet" type="text/css" href="css/styles.css">
</head>
<body>
    <div class="container-fluid">
        <header class="row bg-primary text-white">
            <div class="col-md-4">
                <h1>VAMPlistic</h1>
                <p>
                    A Vagrant-Based LAMP Environment
                </p>
            </div>
            <div class="row col-md-8">
                <div class="col-md-4">
                    <button type="button" class="btn btn-primary btn-lg active col-md-10 system-panel">System</button>
                </div>
                <div class="col-md-4">
                    <button type="button" class="btn btn-primary btn-lg active col-md-10 packages-panel">Packages</button>
                </div>
                <div class="col-md-4">
                    <button type="button" class="btn btn-primary btn-lg active col-md-10 info-panel">Info</button>
                </div>
            </div>
        </header>

        <div class="panel panel-default show-block" id="system-panel">
            <h3>System</h3>
            <div class="jumbotron">
                <div class="row">
                    <div class="col-md-6">
                        <label>Operating System</label>
                    </div>
                    <div class="col-md-6">
                        <span>TODO:INSERT</span>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <label>CPU</label>
                    </div>
                    <div class="col-md-6">
                        <span>TODO:INSERT</span>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <label>RAM</label>
                    </div>
                    <div class="col-md-6">
                        <span>TODO:INSERT</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel panel-default hidden" id="packages-panel">
            <h3>Aptitude Packages</h3>
            <div class="jumbotron">

                <?php foreach ($VAMP_PKGS_DATA as $package => $data): ?>
                    <div class="row">
                        <div class="col-sm-4">
                            <?php echo $package; ?>
                        </div>

                        <div class="col-sm-4">
                            <?php if (isset($data["installed"]) && $data["installed"]): ?>
                                <span class="badge badge-pill badge-success">Installed</span>
                            <?php else: ?>
                                <span class="badge badge-pill badge-danger">Not Installed</span>
                            <?php endif; ?>
                        </div>
                        
                        <div class="col-sm-4">
                            <span class="badge badge-pill badge-info"><?php echo $data["version"]; ?></span>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="panel panel-default hidden" id="info-panel">
            <h3>MariaDB Credentials</h3>
            <div class="jumbotron">
                <div class="row">
                    <div class="col-md-6">
                        User:
                    </div>
                    <div class="col-md-6">
                        <?php echo VAMP_DB_USER; ?>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        Pass:
                    </div>
                    <div class="col-md-6">
                        <?php echo VAMP_DB_PASS; ?>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        Database:
                    </div>
                    <div class="col-md-6">
                        <?php echo VAMP_DB_NAME; ?>
                    </div>
                </div>
            </div>
            <h3>PHP Info</h3>
            <div class="jumbotron">
                <div>
                    <?php phpinfo(); ?>
                </div>
            </div>
        </div>

    </div>

    <script type="text/javascript" src="js/lib/jquery-3.2.1.min.js"></script>
    <script type="text/javascript" src="js/lib/popper.min.js"></script>
    <script type="text/javascript" src="js/lib/bootstrap.min.js"></script>
    <script type="text/javascript" src="js/app/main.js"></script>
</body>
</html>