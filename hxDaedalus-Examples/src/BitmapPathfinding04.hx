package;

import hxDaedalus.ai.EntityAI;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.factories.BitmapObject;
import hxDaedalus.factories.RectMesh;
import hxDaedalus.view.SimpleView;
import hxDaedalus.swing.BasicSwing;
import haxe.Timer;
import java.awt.Graphics2D;
import java.javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.javax.swing.ImageIcon;
import java.javax.swing.JLabel;
import java.awt.event.*;

typedef Bmp = BufferedImage;

class BitmapPathfinding04 extends BasicSwing {
	var mouseX:			Float;
	var mouseY:			Float;
	var mesh:  			Mesh;
	var view:  			SimpleView;
	var entityAI: 		EntityAI;
	var pathfinder:		PathFinder;
	var path: 			Array<Float>;
	var pathSampler: 	LinearPathSampler;
	var object: 		Object;
	var bmp:			Bmp;
	var overlay: 		Bmp;
    var newPath:		Bool = false;

	public static function main(): Void {
		new BitmapPathfinding04();
	}

	public function new() {
		super();
		mesh = RectMesh.buildRectangle( 1024, 780 ); // build a rectangular 2 polygons mesh
		// load images
		try {
			bmp = ImageIO.read(new java.io.File( "../assets/galapagosBW.png" ));
			overlay = ImageIO.read(new java.io.File( "../assets/galapagosColor.png" ));
		} catch (e:Dynamic) {
			throw e;
		}
		getContentPane().add( new JLabel( new ImageIcon( bmp ) )); // show the source bmp
		add(new JLabel(new ImageIcon( overlay ))); // show the image bmp
		view = new SimpleView( this );
		surface.paintFunction = paintFunction;
		var bd = bmp;
		object = BitmapObject.buildFromBmpData( bd, 1.8 ); // create an object from bitmap
		object.x = 0;
		object.y = 0;
		var s = haxe.Timer.stamp();
		mesh.insertObject( object );
		//trace("meshInsert: " + (haxe.Timer.stamp() - s));		
		entityAI = new EntityAI(); // we need an entity
		entityAI.radius = 4; // set radius size for your entity
		entityAI.x = 50; // set a position
		entityAI.y = 50;
		mouseX = Std.int( entityAI.x );
		mouseY = Std.int( entityAI.y );	
		pathfinder = new PathFinder();// now configure the pathfinder
		pathfinder.entity = entityAI; // set the entity
		pathfinder.mesh = mesh; // set the mesh
		path = new Array<Float>(); // we need a vector to store the path
		pathSampler = new LinearPathSampler(); // then configure the path sampler
		pathSampler.entity = entityAI;
		pathSampler.samplingDistance = 10;
		pathSampler.path = path;
        var timer = new Timer( Math.floor( 1000/30 ) );
        timer.run = onEnterFrame;
	}
    
    function onEnterFrame(): Void {
        surface.repaint();
    }
    
    function paintFunction( g: Graphics2D ): Void {
        view.refreshGraphics2D( g );
		g.drawImage( overlay, null, 0, 0 );
        view.drawMesh( mesh );
		if( newPath ){
            pathfinder.findPath( mouseX, mouseY, path ); // find path !
            view.drawPath( path );	// show path on screen
            pathSampler.reset();	// reset the path sampler to manage new generated path
        }
        if( pathSampler.hasNext ) pathSampler.next(); // animate ! move entity     
		view.drawEntity( entityAI ); // show entity new position on screen
    }
	
	override public function mouseReleased( e: MouseEvent ) {
		newPath = false;
    }
    
	override public function mousePressed( e: MouseEvent ) {
		newPath = true;
    }
    
	// only gets called when the mouse is not already down ( needed for first render )
	override public function mouseMoved( e: MouseEvent ) {
		mouseX = e.getPoint().getX();
		mouseY = e.getPoint().getY();
	}
	
	// This is what gets called in place of mouseMoved when mouse is down.
	override public function mouseDragged( e: MouseEvent ) {
		mouseX = e.getPoint().getX();
		mouseY = e.getPoint().getY();
	}
	
	override public function keyPressed( e: KeyEvent ) {
		if( e.getKeyCode() == KeyEvent.VK_ESCAPE ) Sys.exit( 1 );
 	}
}